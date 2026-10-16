namespace SportBook.API.Models
{
    public class Court
    {
        public Guid CourtId { get; set; }
        public Guid FacilityId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? SurfaceType { get; set; }
        public bool IsIndoor { get; set; }
        public int PlayerCapacity { get; set; }
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public bool IsActive { get; set; }

        public SportsFacility? SportsFacility { get; set; }
        public List<CourtSport>? CourtSports { get; set; }
        public List<WorkingHours>? WorkingHours { get; set; }
        public List<TimeSlot>? TimeSlots { get; set; }
    }
}
