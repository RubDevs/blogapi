class PostReportMailer < ApplicationMailer
    def post_mail(user, post, post_report)
        @post = post
        mail to: user.email, subject: "Post #{post.id} report"
    end
end
