class GmailEmail
  def initialize(mail)
    @mail = mail
  end

  def text_after(scan)
    should_return_next = false

    text.lines.each do |line|
      return line.strip if should_return_next
      should_return_next ||= !!line.match(scan)
    end

    nil
  end

  def capture(scan)
    text.lines.each do |line|
      result, _ = line.match(scan)&.captures
      return result if !result.nil?
    end
    nil
  end

  def text
    html.text.lines.map(&:strip).reject(&:blank?).join("\n")
  end

  def html
    body = @mail.payload.parts.last.body.data
    if body.blank?
      body = @mail.payload.parts.last.parts.last.body.data
    end
    Nokogiri::HTML(body)
  end

  def raw
    @mail
  end
end