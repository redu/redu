class Experience < ActiveRecord::Base
  # Representa uma experiência profissional vivida por um usuário, deste modo
  # faz parte do currículo do mesmo.

  belongs_to :user
  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy

  attr_protected :user

  validates :title, :company, :start_date, :user, :presence => true
  validate :start_before_end_date,
    :unless => Proc.new { |exp| exp.end_date.nil? or exp.start_date.nil? }
  validates :end_date, :presence => true,
    :if => Proc.new { |exp| exp.current == false }
  validate :end_date_absense, :if => Proc.new { |exp| exp.current == true }

  scope :actual_jobs, where(:end_date => nil)

  private

  # Verifica se o start_date ocorre antes do end_date
  def start_before_end_date
    if self.end_date < self.start_date
      self.errors.add(:start_date, "deve ocorrer antes da #{I18n.t 'activerecord.attributes.experience.end_date'}")
    end
  end

  def end_date_absense
    unless self.end_date.nil?
      self.errors.add(:end_date, "não deve existir, já que é uma experiência atual")
    end
  end
end
