namespace :boxwalker do
  desc "Delete documents associated with an eadid from the index, as well as generated files"
  task :delete_finding_aid, [ :eadid ] => :environment do |t, args|
    DeleteFindingAidJob.perform_later(args[:eadid])
  end
end

