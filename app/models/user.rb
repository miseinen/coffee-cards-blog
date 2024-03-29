class User < ApplicationRecord
  before_create :confirmation_token
  before_save { self.email = email.downcase }

  has_many :coffeecards, dependent: :destroy
  has_many :likes, dependent: :destroy

  I18n.t(:username)
  I18n.t(:about)
  I18n.t(:password)

  VALID_USERNAME_REGEX = /\A[a-zA-Z0-9а-яА-ЯўІі]+\z/.freeze
  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: VALID_USERNAME_REGEX,
                                 message: :bad_username },
                       length: 3..25

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: VALID_EMAIL_REGEX },
                    length: { maximum: 105 },
                    confirmation: true

  has_secure_password

  validates :about, allow_blank: true,
                    length: 0..250

  VALID_PASSWORD_REGEX = /\A(?=.*\d)(?=.*([a-z]))(?=.*[@#$%^&+=]).{8,}\z/i.freeze
  validates :password, format: { with: VALID_PASSWORD_REGEX, message: :bad_password,
                                 if: proc { |user| user.password.present? } }

  def send_password_reset
    generate_token(:reset_password_token)
    self.reset_password_sent_at = Time.zone.now
    save!
    UserMailer.forgot_password(self).deliver
  end

  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless User.exists?(column => self[column])
    end
  end

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save!(validate: false)
  end

  private

    def confirmation_token
      return if confirm_token.blank?

      self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
end
