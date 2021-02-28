class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :rememberable,
         :omniauthable

  has_many :invoices

  def client
    @client ||= Signet::OAuth2::Client.new(
          token_credential_uri: 'https://oauth2.googleapis.com/token',
          client_id: GoogleCreds.client_id,
          client_secret: GoogleCreds.client_secret,
          refresh_token: self.authorization['refresh_token'],
          access_token: self.authorization['token'],
          expires_at: self.authorization['expires_at']
        )
  end

  def email_id_each
    client.refresh!

    gmail = Google::Apis::GmailV1::GmailService.new
    gmail.authorization = client

    next_page = nil
    begin
      result = gmail.list_user_messages('me', q: 'grab "Diterbitkan oleh Pengemudi" -"Tip darimu sudah disalurkan ke pengemudimu"', page_token: next_page)
      result.messages.each do |message|        
        yield(message.id)
      end
      next_page = result.next_page_token
    end while next_page
  end

  def find_email(email_id)
    client.refresh!

    gmail = Google::Apis::GmailV1::GmailService.new
    gmail.authorization = client

    gmail_email = gmail.get_user_message('me', email_id)
    GmailEmail.new(gmail_email)
  end

  def email_first
    client = Signet::OAuth2::Client.new(
          token_credential_uri: 'https://oauth2.googleapis.com/token',
          client_id: GoogleCreds.client_id,
          client_secret: GoogleCreds.client_secret,
          refresh_token: self.authorization['refresh_token'],
          access_token: self.authorization['token'],
          expires_at: self.authorization['expires_at']
        )
    client.refresh!

    gmail = Google::Apis::GmailV1::GmailService.new
    gmail.authorization = client

    result = gmail.list_user_messages('me', q: 'grab "Diterbitkan oleh Pengemudi" -"Tip darimu sudah disalurkan ke pengemudimu"')
    message_id = result.messages.first.id
    return GmailEmail.new(gmail.get_user_message('me', message_id))
  end


end
