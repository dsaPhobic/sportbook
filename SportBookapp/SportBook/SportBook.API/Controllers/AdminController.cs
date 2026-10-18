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
    [Authorize(Roles = "administrator")]
    public class AdminController : ControllerBase
    {
        private readonly SportBookContext _context;

        public AdminController(SportBookContext context)
        {
            _context = context;
        }

        // Returns all reservations in the system (admin overview)
        [HttpGet("reservations")]
        public async Task<IActionResult> GetAllReservations()
        {
            var reservations = await _context.Reservations
                .Include(r => r.User)
                .Include(r => r.TimeSlot)
                .OrderByDescending(r => r.ReservationDate)
                .ToListAsync();

            return Ok(reservations);
        }

        // Admin scans user QR code at court entrance
        [HttpPost("scan")]
        public async Task<IActionResult> ScanQRCode([FromBody] ScanQRCodeDTO dto)
        {
            var qrCode = await _context.QRCodes
                .Include(q => q.Reservation)
                .FirstOrDefaultAsync(q => q.CodeValue == dto.CodeValue);

            if (qrCode == null)
                return NotFound("QR code not found.");

            if (qrCode.IsUsed)
                return BadRequest("QR code has already been used.");

            if (qrCode.ExpiryDate < DateTime.Now)
                return BadRequest("QR code has expired.");

            qrCode.IsUsed = true;
            await _context.SaveChangesAsync();

            return Ok(new { message = "QR code scanned successfully.", reservation = qrCode.Reservation });
        }

        // Blocks a court for a specified time range
        [HttpPost("block")]
        public async Task<IActionResult> BlockTimeSlot([FromBody] BlockTimeSlotDTO dto)
        {
            var court = await _context.Courts
                .FirstOrDefaultAsync(c => c.CourtId == dto.CourtId);
            if (court == null)
                return NotFound("Court not found.");

            var block = new CourtBlock
            {
                CourtBlockId = Guid.NewGuid(),
                CourtId = dto.CourtId,
                BlockedByUserId = dto.AdminId,
                BlockStart = dto.BlockStart,
                BlockEnd = dto.BlockEnd,
                Reason = dto.Reason
            };

            _context.CourtBlocks.Add(block);
            await _context.SaveChangesAsync();

            return Ok(block);
        }
    }
}
