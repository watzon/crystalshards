class Job::Github::ProjectURLUpdatePeriodicJob < Mosquito::PeriodicJob
  run_every 1.hour

  def perform
    Project.query.where { (provider == "github") & (api_id == nil) }.select("uri").each_with_cursor(100) do |project|
      if (repo = ::Service::Github.fetch(url: project.url))
        ProjectUpdateQueuedJob.with_payload(repo).enqueue
      end
    end
  end
end
