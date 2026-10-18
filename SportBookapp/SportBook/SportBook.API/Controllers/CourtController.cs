using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SportBook.API.Data;
using SportBook.API.Models;

namespace SportBook.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CourtController : ControllerBase
    {
        private readonly SportBookContext _context;

        public CourtController(SportBookContext context)
        {
            _context = context;
        }

        // Returns a list of all active courts with their average rating
        [HttpGet]
        public async Task<IActionResult> GetAllCourts()
        {
            var courts = await _context.Courts
                .Where(t => t.IsActive)
                .Select(t => new {
                    courtId = t.CourtId,
                    name = t.Name,
                    surfaceType = t.SurfaceType,
                    isIndoor = t.IsIndoor,
                    playerCapacity = t.PlayerCapacity,
                    averageRating = _context.Reviews
                        .Where(r => r.IsApproved && r.Reservation != null && r.Reservation.TimeSlot != null && r.Reservation.TimeSlot.CourtId == t.CourtId)
                        .Average(r => (double?)r.Rating)
                })
                .ToListAsync();

            return Ok(courts);
        }

        // Returns details of a specific court by ID
        [HttpGet("{id}")]
        public async Task<IActionResult> GetCourt(Guid id)
        {
            var court = await _context.Courts
                .Include(t => t.CourtSports!)
                    .ThenInclude(ts => ts.Sport)
                .Include(t => t.WorkingHours)
                .FirstOrDefaultAsync(t => t.CourtId == id);

            if (court == null)
                return NotFound("Court not found.");

            var result = new {
                courtId = court.CourtId,
                name = court.Name,
                surfaceType = court.SurfaceType,
                isIndoor = court.IsIndoor,
                playerCapacity = court.PlayerCapacity,
                courtSports = court.CourtSports,
                workingHours = court.WorkingHours?.Select(wh => new {
                    dayOfWeek = (int)wh.DayOfWeek,
                    startTime = wh.StartTime,
                    endTime = wh.EndTime,
                    slotDurationMinutes = wh.SlotDurationMinutes
                })
            };

            return Ok(result);
        }

        // Returns a list of all sports in the system
        [HttpGet("sports")]
        public async Task<IActionResult> GetAllSports()
        {
            var sports = await _context.Sports.ToListAsync();
            return Ok(sports);
        }
    }
}
