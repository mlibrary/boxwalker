namespace :boxwalker do
  desc "Delete documents associated with an eadid from the index, as well as generated files"
  task :delete_finding_aid, [ :eadid ] => :environment do |t, args|
    eadid = args[:eadid]
    raise Boxwalker::Error, "eadid is required." if eadid.blank?
    DeleteFindingAidJob.perform_later(eadid)
  end
end
