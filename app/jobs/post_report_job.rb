class PostReportJob < ApplicationJob
  queue_as :default

  def perform(user_id, post_id)
    user = User.find(user_id)
    post = Post.find(post_id)
    report = PostReport.generate(post)

    PostReportMailer.post_mail(user, post, report).deliver_now
    # Do something later
  end
end
