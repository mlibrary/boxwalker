namespace :boxwalker do
  desc "Delete documents associated with an eadi from the index"
  task :delete_from_index, [ :eadid ] => :environment do |t, args|
    DeleteFindingAidJob.perform_later(args[:eadid])
  end
end

