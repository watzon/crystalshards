class Job::Github::ProjectURLUpdatePeriodicJob < Mosquito::PeriodicJob
  run_every 1.hour

  def perform
    Project.query.where { (provider == "github") & (api_id == nil) }.select("uri").each_with_cursor(100) do |project|
      repo = ::Service::Github.fetch(url: project.uri)
      ProjectUpdateQueuedJob.new(
        api_id: repo.id,
        url: repo.url,
        watcher_count: repo.watchers.total_count || 0,
        fork_count: repo.forks.total_count || 0,
        star_count: repo.stargazers.total_count || 0,
        pull_request_count: repo.pull_requests.total_count || 0,
        issue_count: repo.issues.total_count || 0,
        release_tags: (nodes = repo.tags.nodes) ? nodes.map(&.name).join(",") : "",
        name_with_owner: repo.name_with_owner
      ).enqueue
    end
  end
end