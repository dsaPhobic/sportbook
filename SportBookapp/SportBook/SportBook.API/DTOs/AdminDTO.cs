namespace SportBook.API.DTOs
{
    public class ScanQRCodeDTO
    {
        public string CodeValue { get; set; } = string.Empty;
    }

    public class BlockTimeSlotDTO
    {
        public Guid CourtId { get; set; }
        public Guid AdminId { get; set; }
        public DateTime BlockStart { get; set; }
        public DateTime BlockEnd { get; set; }
        public string? Reason { get; set; }
    }
}
