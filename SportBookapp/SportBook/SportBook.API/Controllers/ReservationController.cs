using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SportBook.API.Data;
using SportBook.API.Models;
using SportBook.API.DTOs;
using Microsoft.AspNetCore.Authorization;

namespace SportBook.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ReservationController : ControllerBase
    {
        private readonly SportBookContext _context;

        public ReservationController(SportBookContext context)
        {
            _context = context;
        }

        // Creates a new reservation for a user
        [HttpPost]
        public async Task<IActionResult> CreateReservation([FromBody] CreateReservationDTO dto)
        {
            var timeSlot = await _context.TimeSlots
                .FirstOrDefaultAsync(t => t.TimeSlotId == dto.TimeSlotId);

            if (timeSlot == null)
                return NotFound("Time slot not found.");

            if (timeSlot.Status != "free")
                return BadRequest("Time slot is not available.");

            var existingActive = await _context.Reservations
                .FirstOrDefaultAsync(r => r.TimeSlotId == dto.TimeSlotId && r.Status == "active");

            if (existingActive != null)
                return BadRequest("Time slot already has an active reservation.");

            var slotStart = timeSlot.Date.ToDateTime(timeSlot.StartTime);
            var slotEnd = timeSlot.Date.ToDateTime(timeSlot.EndTime);

            var block = await _context.CourtBlocks
                .FirstOrDefaultAsync(b => b.CourtId == timeSlot.CourtId &&
                    b.BlockStart <= slotEnd &&
                    b.BlockEnd >= slotStart);

            if (block != null)
                return BadRequest("Court is blocked during this period.");

            var reservation = new Reservation
            {
                ReservationId = Guid.NewGuid(),
                UserId = dto.UserId,
                TimeSlotId = dto.TimeSlotId,
                ReservationDate = DateTime.Now,
                Status = "active",
                TotalPrice = timeSlot.Price,
                PaymentStatus = "pending",
                Note = dto.Note
            };

            timeSlot.Status = "booked";

            var qrCode = new QRCode
            {
                QRCodeId = Guid.NewGuid(),
                ReservationId = reservation.ReservationId,
                CodeValue = $"SPORTBOOK-{reservation.ReservationId}",
                GeneratedDate = DateTime.Now,
                ExpiryDate = DateTime.Now.AddDays(7),
                IsUsed = false
            };

            _context.Reservations.Add(reservation);
            _context.QRCodes.Add(qrCode);
            _context.TimeSlots.Update(timeSlot);

            await _context.SaveChangesAsync();

            return Ok(new { reservation, qrCode });
        }

        // Returns reservations for a specific user
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserReservations(Guid userId)
        {
            var reservations = await _context.Reservations
                .Include(r => r.TimeSlot)
                    .ThenInclude(t => t!.Court)
                .Include(r => r.QRCode)
                .Where(r => r.UserId == userId)
                .OrderByDescending(r => r.ReservationDate)
                .Select(r => new {
                    reservationId = r.ReservationId,
                    status = r.Status,
                    totalPrice = r.TotalPrice,
                    reservationDate = r.ReservationDate,
                    note = r.Note,
                    qrCode = r.QRCode == null ? null : new {
                        codeValue = r.QRCode.CodeValue
                    },
                    timeSlot = r.TimeSlot == null ? null : new {
                        date = r.TimeSlot.Date,
                        startTime = r.TimeSlot.StartTime,
                        endTime = r.TimeSlot.EndTime,
                        courtName = r.TimeSlot.Court != null ? r.TimeSlot.Court.Name : null
                    }
                })
                .ToListAsync();

            return Ok(reservations);
        }

        // Cancels an active reservation
        [HttpPut("{id}/cancel")]
        public async Task<IActionResult> CancelReservation(Guid id)
        {
            var reservation = await _context.Reservations
                .Include(r => r.TimeSlot)
                .FirstOrDefaultAsync(r => r.ReservationId == id);

            if (reservation == null)
                return NotFound("Reservation not found.");

            if (reservation.Status == "cancelled")
                return BadRequest("Reservation has already been cancelled.");

            reservation.Status = "cancelled";

            if (reservation.TimeSlot != null)
            {
                reservation.TimeSlot.Status = "free";
            }

            await _context.SaveChangesAsync();

            return Ok("Reservation successfully cancelled.");
        }
    }
}
