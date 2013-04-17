class DecoratedEnrollmentsStrategy < Struct.new(:subjects, :user_role_pairs)
  def to_a
    decorate_with_subject_ids
  end

  private

  def decorate_with_subject_ids
    subjects.reduce([]) do |memo, subject|
      user_role_pairs.each do |(user, role)|
        memo << [user.id, subject.id, role]
      end
      memo
    end
  end
end


