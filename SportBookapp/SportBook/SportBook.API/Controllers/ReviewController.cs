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
    public class ReviewController : ControllerBase
    {
        private readonly SportBookContext _context;

        public ReviewController(SportBookContext context)
        {
            _context = context;
        }

        // Adds a new review for a completed time slot
        [Authorize]
        [HttpPost]
        public async Task<IActionResult> AddReview([FromBody] AddReviewDTO dto)
        {
            var reservation = await _context.Reservations
                .Include(r => r.TimeSlot)
                .FirstOrDefaultAsync(r => r.ReservationId == dto.ReservationId);

            if (reservation == null)
                return NotFound("Reservation not found.");

            if (reservation.Status != "active")
                return BadRequest("Reservation is not active.");

            if (reservation.TimeSlot == null || reservation.TimeSlot.Date > DateOnly.FromDateTime(DateTime.Now))
                return BadRequest("You can only leave a review after the time slot has passed.");

            var existingReview = await _context.Reviews
                .FirstOrDefaultAsync(r => r.ReservationId == dto.ReservationId);

            if (existingReview != null)
                return BadRequest("A review for this reservation already exists.");

            var review = new Review
            {
                ReviewId = Guid.NewGuid(),
                ReservationId = dto.ReservationId,
                Rating = dto.Rating,
                Comment = dto.Comment,
                Date = DateTime.Now,
                IsApproved = true
            };

            _context.Reviews.Add(review);
            await _context.SaveChangesAsync();

            return Ok(review);
        }

        // Returns all approved reviews for a specific court, sorted newest first
        [HttpGet("court/{courtId}")]
        public async Task<IActionResult> GetCourtReviews(Guid courtId)
        {
            var reviews = await _context.Reviews
                .Include(r => r.Reservation)
                    .ThenInclude(res => res!.User)
                .Include(r => r.Reservation)
                    .ThenInclude(res => res!.TimeSlot)
                .Where(r => r.Reservation != null &&
                            r.Reservation.TimeSlot != null &&
                            r.Reservation.TimeSlot.CourtId == courtId &&
                            r.IsApproved)
                .OrderByDescending(r => r.Date)
                .Select(r => new {
                    reviewId = r.ReviewId,
                    rating = r.Rating,
                    comment = r.Comment,
                    date = r.Date,
                    reservation = new {
                        user = new {
                            firstName = r.Reservation!.User!.FirstName
                        }
                    }
                })
                .ToListAsync();

            return Ok(reviews);
        }
    }
}
