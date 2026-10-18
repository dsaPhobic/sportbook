using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using SportBook.API.Data;
using SportBook.API.DTOs;
using SportBook.API.Models;

namespace SportBook.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TimeSlotController : ControllerBase
    {
        private readonly SportBookContext _context;

        public TimeSlotController(SportBookContext context)
        {
            _context = context;
        }

        // Returns list of time slots for a specific court on a given date
        [HttpGet("{courtId}/{date}")]
        public async Task<IActionResult> GetTimeSlots(Guid courtId, DateOnly date)
        {
            var court = await _context.Courts
                .FirstOrDefaultAsync(t => t.CourtId == courtId);

            if (court == null)
                return NotFound("Court not found.");

            var slots = await _context.TimeSlots
                .Where(t => t.CourtId == courtId && t.Date == date)
                .OrderBy(t => t.StartTime)
                .ToListAsync();

            return Ok(slots);
        }

        // Automatically generates time slots for a court on a date based on working hours
        [Authorize(Roles = "administrator")]
        [HttpPost("generate")]
        public async Task<IActionResult> GenerateTimeSlots([FromBody] GenerateTimeSlotsDTO dto)
        {
            var workingHours = await _context.WorkingHours
                .FirstOrDefaultAsync(wh => wh.CourtId == dto.CourtId &&
                    wh.DayOfWeek == (short)dto.Date.DayOfWeek);

            if (workingHours == null)
                return BadRequest("Court is not open on this day.");

            var existingSlots = await _context.TimeSlots
                .Where(t => t.CourtId == dto.CourtId && t.Date == dto.Date)
                .ToListAsync();

            if (existingSlots.Any())
                return Ok("Time slots already exist for this day.");

            var courtSport = await _context.CourtSports
                .FirstOrDefaultAsync(cs => cs.CourtId == dto.CourtId &&
                    cs.IsPrimarySport);

            if (courtSport == null)
                return BadRequest("Court has no primary sport defined.");

            if (workingHours.SlotDurationMinutes <= 0)
                return BadRequest("Time slot duration must be greater than 0 minutes.");

            var slots = new List<TimeSlot>();
            var currentTime = workingHours.StartTime;

            while (currentTime.Add(TimeSpan.FromMinutes(workingHours.SlotDurationMinutes))
                <= workingHours.EndTime)
            {
                slots.Add(new TimeSlot
                {
                    TimeSlotId = Guid.NewGuid(),
                    CourtId = dto.CourtId,
                    SportId = courtSport.SportId,
                    Date = dto.Date,
                    StartTime = currentTime,
                    EndTime = currentTime.Add(TimeSpan.FromMinutes(workingHours.SlotDurationMinutes)),
                    Price = courtSport.PricePerHour,
                    Status = "free"
                });

                currentTime = currentTime.Add(
                    TimeSpan.FromMinutes(workingHours.SlotDurationMinutes));
            }

            await _context.TimeSlots.AddRangeAsync(slots);
            await _context.SaveChangesAsync();

            return Ok(slots);
        }
    }
}
