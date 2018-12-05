# -- MODULES

module Blog

    # -- OPERATIONS

    def add_comment(
        context : HTTP::Server::Context,
        article_id : Int32
        )

        session = Session.new( context );

        text = context.params.body[ "text" ];
        article = get_article_by_id( article_id );
        add_comment( article_id, session.user_id, text );

        session.message = "Your comment has been added.";
        session.store( context );

        context.redirect( session.path );
    end
end
