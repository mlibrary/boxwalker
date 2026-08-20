# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { described_class.new(email: 'user@example.com', password: 'password123') }

  describe 'validations' do
    it 'is valid with an email and password' do
      expect(user).to be_valid
    end

    it 'requires an email' do
      user.email = ''
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'requires a valid email format' do
      user.email = 'not-an-email'
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'requires the email to be unique (case-insensitively)' do
      described_class.create!(email: 'user@example.com', password: 'password123')
      duplicate = described_class.new(email: 'USER@example.com', password: 'password123')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include('has already been taken')
    end

    it 'requires a password' do
      user.password = nil
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it 'requires the password and its confirmation to match' do
      user.password_confirmation = 'mismatch'
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to be_present
    end
  end

  describe 'devise modules' do
    it 'enables the expected devise modules' do
      expect(described_class.devise_modules).to include(
        :database_authenticatable,
        :registerable,
        :recoverable,
        :rememberable,
        :validatable
      )
    end

    it 'authenticates with the correct password' do
      user.save!
      expect(user.valid_password?('password123')).to be(true)
      expect(user.valid_password?('wrong')).to be(false)
    end

    it 'encrypts the password rather than storing it in plain text' do
      user.save!
      expect(user.encrypted_password).to be_present
      expect(user.encrypted_password).not_to eq('password123')
    end
  end

  describe 'attributes' do
    it 'defaults guest to false' do
      expect(described_class.new.guest).to be(false)
    end
  end

  describe 'Blacklight integration' do
    it 'exposes email as the displayable login key' do
      expect(described_class.string_display_key).to eq(:email)
    end

    it 'includes Blacklight::User' do
      expect(described_class.ancestors).to include(Blacklight::User)
    end
  end
end
