# -- MODULES

module Blog

    # -- OPERATIONS

    def disconnect_user(
        context : HTTP::Server::Context
        )

        session = Session.new( context );

        session.user_is_connected = false;
        session.store( context );

        context.redirect( session.path );
    end
end
