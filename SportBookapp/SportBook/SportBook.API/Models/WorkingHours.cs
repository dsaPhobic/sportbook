namespace SportBook.API.Models
{
    public class WorkingHours
    {
        public Guid WorkingHoursId { get; set; }
        public Guid CourtId { get; set; }
        public short DayOfWeek { get; set; }
        public TimeOnly StartTime { get; set; }
        public TimeOnly EndTime { get; set; }
        public int SlotDurationMinutes { get; set; }

        public Court? Court { get; set; }
    }
}
