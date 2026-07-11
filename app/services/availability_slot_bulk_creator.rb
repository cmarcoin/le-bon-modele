class AvailabilitySlotBulkCreator
  SLOT_DURATION = 45.minutes
  SLOT_INTERVAL = 1.hour

  DEFAULT_COLLEAGUE_NAME = "Équipe Le Bon Modèle"
  DEFAULT_COLLEAGUE_EMAIL = "contact@lebonmodele.fr"

  Result = Struct.new(:created_count, :skipped_count, :errors, keyword_init: true) do
    def success?
      errors.empty?
    end
  end

  def initialize(start_date:, end_date:, daily_start_time:, daily_end_time:, timezone: AvailabilitySlot::DEFAULT_TIMEZONE, pack_id: nil, colleague_name: DEFAULT_COLLEAGUE_NAME, colleague_email: DEFAULT_COLLEAGUE_EMAIL)
    @start_date = start_date
    @end_date = end_date
    @daily_start_time = daily_start_time
    @daily_end_time = daily_end_time
    @timezone = timezone
    @pack_id = pack_id.presence
    @colleague_name = colleague_name
    @colleague_email = colleague_email
  end

  def call
    errors = validate
    return Result.new(created_count: 0, skipped_count: 0, errors: errors) if errors.any?

    zone = ActiveSupport::TimeZone[@timezone]
    created = 0
    skipped = 0

    (@start_date..@end_date).each do |date|
      slot_time = zone.parse("#{date} #{@daily_start_time}")
      end_boundary = zone.parse("#{date} #{@daily_end_time}")

      while slot_time + SLOT_DURATION <= end_boundary
        if AvailabilitySlot.exists?(starts_at: slot_time)
          skipped += 1
        else
          AvailabilitySlot.create!(
            starts_at: slot_time,
            ends_at: slot_time + SLOT_DURATION,
            timezone: @timezone,
            colleague_name: @colleague_name,
            colleague_email: @colleague_email,
            pack_id: @pack_id,
            active: true
          )
          created += 1
        end

        slot_time += SLOT_INTERVAL
      end
    end

    Result.new(created_count: created, skipped_count: skipped, errors: [])
  end

  private

  def validate
    errors = []
    errors << "La date de début est obligatoire." if @start_date.blank?
    errors << "La date de fin est obligatoire." if @end_date.blank?
    errors << "L'heure de début est obligatoire." if @daily_start_time.blank?
    errors << "L'heure de fin est obligatoire." if @daily_end_time.blank?
    return errors if errors.any?

    errors << "La date de fin doit être après la date de début." if @end_date < @start_date

    start_minutes = time_to_minutes(@daily_start_time)
    end_minutes = time_to_minutes(@daily_end_time)
    errors << "L'heure de fin doit être après l'heure de début." if end_minutes <= start_minutes

    errors << "Fuseau horaire inconnu." if ActiveSupport::TimeZone[@timezone].blank?

    errors
  end

  def time_to_minutes(time_value)
    hours, minutes = time_value.to_s.split(":").map(&:to_i)
    (hours * 60) + minutes
  end
end
