class Invoice < ApplicationRecord
  belongs_to :user
  
  def self.from(gmail_email:, user:)
    total_price      = gmail_email.text_after('TOTAL').strip.gsub(/[^\d]/, '').to_i rescue nil

    if !total_price.nil? && total_price > 0
      pick_up_location ||= gmail_email.text_after('Pesanan Dari:')
      pick_up_at       ||= Time.zone.parse(gmail_email.text_after(/TANGGAL/)) 
      booking_code     ||= gmail_email.text_after('Pesanan ID').strip rescue nil
      booking_code     ||= gmail_email.text_after('Kode Booking').strip if booking_code.nil?
      driver_name      ||= gmail_email.text_after('Diterbitkan oleh Pengemudi').strip
    else
      total_price      ||= gmail_email.text_after('Total').strip.gsub(/[^\d]/, '').to_i
      if total_price == 0
         total_price   = gmail_email.capture(/TOTAL\s+Rp\s+(\d+)/).to_i
      end
      raise 'error!!!' if total_price == 0 || total_price.nil?
      pick_up_at       ||= Time.zone.parse(gmail_email.capture(/Dijemput Pada: (.+)/)) rescue nil
      pick_up_at       ||= Time.zone.parse(gmail_email.text_after('Waktu pengambilan barang')) rescue nil
      raise 'nil pick up at!' if pick_up_at.nil?
      pick_up_location ||= gmail_email.capture(/Lokasi Penjemputan: (.+)/)
      pick_up_location ||= gmail_email.text_after('Lokasi Penjemputan')
      raise 'nil pick_up_location!' if pick_up_location.nil?
      booking_code     ||= gmail_email.capture(/Kode Booking: (.+)/)&.strip
      booking_code     ||= gmail_email.text_after('Kode Booking').strip
      raise 'nil booking code!' if booking_code.nil?
      driver_name      ||= gmail_email.text_after('Diterbitkan oleh pengemudi')&.strip
      driver_name      ||= gmail_email.text_after('Diterbitkan oleh Pengemudi')&.strip
      raise 'driver name nil!' if driver_name.nil?
    end

    if pick_up_at.year < 2000
      pick_up_at += 2000.years
    end

    invoice = Invoice.create_or_find_by(booking_code: booking_code, user_id: user.id)

    invoice.update(
      pick_up_location: pick_up_location,
      total_price: total_price,
      pick_up_at: pick_up_at,
      driver_name: driver_name
    )

    invoice
  end

  def past_driver_invoices
    @past_driver_invoices ||= Invoice.where(user_id: user_id).where(driver_name: driver_name).count
  end
end