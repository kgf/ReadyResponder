class Notification < ActiveRecord::Base
  serialize :individuals
  has_paper_trail
  include Loggable

  has_and_belongs_to_many :departments
  belongs_to :event
  has_many :recipients
  has_many :people, through: :recipients

  STATUS_STATES = {
    'New' => ['Scheduled', 'Active'],
    'Scheduled' => ['Active', 'Cancelled'],
    'Active' => ['Cancelled'],
    'In-Progress' => ['Cancelled'],
    'Cancelled' => [],
    'Complete' => [],
    'Expired' => []
  }

  VALID_STATUSES = STATUS_STATES.keys
  validates :status, inclusion: { in: VALID_STATUSES }
  validate :notification_has_at_least_one_recipient
  validates_presence_of :subject
  validates :id_code, presence: true, allow_blank: true, uniqueness: true

  def available_statuses
    if status
      STATUS_STATES[status]
    else
      STATUS_STATES['New']
    end
  end

  def start_time
    return nil if event.nil?
    event.start_time
  end

  def end_time
    return nil if event.nil?
    event.end_time
  end

  def activate!
    start_time = Time.zone.now
    status = 'In-Progress'
    self.save!
    from_dept = Person.active.where(department: departments)
    indies = Person.active.where(id: self.individuals)
    recievers = from_dept + indies
    recievers.each do |p|
      if (purpose == 'FYI' ||
          purpose == 'Acknowledgment' ||
          purpose == 'Availability' && !p.responded?(self)
        recipients.create(person: p)
      end
    end
    notify!
  end

  def notify!
    if channels.include? 'Text'
      twilio = Message::SendNotificationTextMessage.new
      recipients.each do |r|
        r.notify! twilio
      end
    end
  end

  private

  def notification_has_at_least_one_recipient
    # As we add more ways to choose recipients,
    # we'll need to expand this validator
    if departments.blank? && individuals.blank?
      errors[:departments] << "All recipients can't be blank"
      errors[:individuals] << "All recipients can't be blank"
    end
  end

  # possible future validation
  # def expired?
  #   return false if id_code.present?
  #   Notification.where(id_code: id_code)
  #     .select { |notification| notification.end_time > 6.months.ago }.empty?
  # end

end
