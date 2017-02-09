window.comments = # Show comment forms

  initCommentNew: (comments)->
    console.log "comments.initNewComment #{comments}"
    $(document).on(
      'click'
      "#{comments} .comment-new"
      (e)->
        console.log "comments.CommentNew #{comments}"
        e.preventDefault()
        $comment_form = $('.comment-form')
        $comment_form.toggle()
        $comment_form.find('textarea').focus()
    )

  initCommentReply: (comments)->
    console.log "comments.initCommentReply #{comments}"
    $(document).on(
      'click'
      "#{comments} .comment-reply"
      (e)->
        console.log "comments.CommentReply #{comments}"
        e.preventDefault()
        $reply_form = $(this).closest('.comment').find('.reply-form').first()
        $reply_form.toggle()
        $reply_form.find('textarea').focus()
    )

  initComments: (comments)->
    this.initCommentNew comments
    this.initCommentReply comments

comments.initComments('#activity-log')
