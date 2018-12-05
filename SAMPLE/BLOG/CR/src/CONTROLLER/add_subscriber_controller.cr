# -- MODULES

module Blog

    # -- OPERATIONS

    def add_subscriber(
        context : HTTP::Server::Context
        )

        session = Session.new( context );

        add_subscriber( context.params.body[ "email" ] );

        session.user_has_subscribed = true;
        session.message = "Thanks for your subscription.";
        session.store( context );

        context.redirect( session.path );
    end
end
