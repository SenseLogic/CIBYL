# -- MODULES

module Blog

    # -- OPERATIONS

    def connect_user(
        context : HTTP::Server::Context
        )

        session = Session.new( context );

        user \
            = get_user_by_pseudonym_and_password(
                  context.params.body[ "pseudonym" ],
                  context.params.body[ "password" ]
                  );

        if ( user.nil?() )

            session.message = "Invalid pseudonym or password.";

        else

            session.user_id = user.id;
            session.user_is_connected = true;
            session.user_is_administrator = user.is_administrator;
        end

        session.store( context );

        context.redirect( session.path );
    end
end
