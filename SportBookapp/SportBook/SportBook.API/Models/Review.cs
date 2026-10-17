namespace SportBook.API.Models
{
    public class Review
    {
        public Guid ReviewId { get; set; }
        public Guid ReservationId { get; set; }
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime Date { get; set; }
        public bool IsApproved { get; set; }

        public Reservation? Reservation { get; set; }
    }
}
