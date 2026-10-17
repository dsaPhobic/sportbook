namespace SportBook.API.Models
{
    public class QRCode
    {
        public Guid QRCodeId { get; set; }
        public Guid ReservationId { get; set; }
        public string CodeValue { get; set; } = string.Empty;
        public DateTime GeneratedDate { get; set; }
        public DateTime ExpiryDate { get; set; }
        public bool IsUsed { get; set; }

        public Reservation? Reservation { get; set; }
    }
}
