using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SportBook.API.Data;
using SportBook.API.Models;
using SportBook.API.DTOs;

namespace SportBook.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EquipmentController : ControllerBase
    {
        private readonly SportBookContext _context;

        public EquipmentController(SportBookContext context)
        {
            _context = context;
        }

        // Returns all active equipment items
        [HttpGet]
        public async Task<IActionResult> GetAllEquipment()
        {
            var equipment = await _context.Equipment
                .Where(o => o.IsActive)
                .ToListAsync();

            return Ok(equipment);
        }

        // Adds equipment to an existing reservation
        [HttpPost("add")]
        public async Task<IActionResult> AddEquipment([FromBody] AddEquipmentDTO dto)
        {
            var reservation = await _context.Reservations
                .FirstOrDefaultAsync(r => r.ReservationId == dto.ReservationId);

            if (reservation == null)
                return NotFound("Reservation not found.");

            var equipment = await _context.Equipment
                .FirstOrDefaultAsync(o => o.EquipmentId == dto.EquipmentId);

            if (equipment == null)
                return NotFound("Equipment not found.");

            if (equipment.AvailableQuantity < dto.Quantity)
                return BadRequest("Insufficient equipment in stock.");

            var reservationEquipment = new ReservationEquipment
            {
                Id = Guid.NewGuid(),
                ReservationId = dto.ReservationId,
                EquipmentId = dto.EquipmentId,
                Quantity = dto.Quantity,
                TotalPrice = equipment.RentalPrice * dto.Quantity
            };

            equipment.AvailableQuantity -= dto.Quantity;

            _context.ReservationEquipment.Add(reservationEquipment);
            _context.Equipment.Update(equipment);
            await _context.SaveChangesAsync();

            return Ok(reservationEquipment);
        }
    }
}
