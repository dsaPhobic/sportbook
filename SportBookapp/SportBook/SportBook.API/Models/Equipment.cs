namespace SportBook.API.Models
{
    public class Equipment
    {
        public Guid EquipmentId { get; set; }
        public Guid FacilityId { get; set; }
        public string Name { get; set; } = string.Empty;
        public decimal RentalPrice { get; set; }
        public int AvailableQuantity { get; set; }
        public bool IsActive { get; set; }

        public SportsFacility? SportsFacility { get; set; }
        public List<ReservationEquipment>? ReservationEquipment { get; set; }
    }
}
