namespace SportBook.API.Models
{
    public class TimeSlot
    {
        public Guid TimeSlotId { get; set; }
        public Guid CourtId { get; set; }
        public Guid SportId { get; set; }
        public DateOnly Date { get; set; }
        public TimeOnly StartTime { get; set; }
        public TimeOnly EndTime { get; set; }
        public decimal Price { get; set; }
        public string Status { get; set; } = "free"; // "free" or "booked"

        public Court? Court { get; set; }
        public Sport? Sport { get; set; }
        public Reservation? Reservation { get; set; }
    }
}
