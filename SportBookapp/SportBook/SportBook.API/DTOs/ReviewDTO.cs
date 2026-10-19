namespace SportBook.API.DTOs
{
    public class AddReviewDTO
    {
        public Guid ReservationId { get; set; }
        public int Rating { get; set; }
        public string? Comment { get; set; }
    }
}
