# -- MODULES

module Blog

    # -- TYPES

    class Session

        # -- ATTRIBUTES

        property \
            path : String,
            message : String,
            user_id : Int32,
            user_is_connected : Bool,
            user_is_administrator : Bool,
            user_has_subscribed : Bool;

        # -- CONSTRUCTORS

        def initialize(
            context : HTTP::Server::Context
            ) : Void

            @path = get_session_string( context, "Path", "" );
            @message = get_session_string( context, "Message", "" );
            @user_id = get_session_integer( context, "UserId", 0 );
            @user_is_connected = get_session_boolean( context, "UserIsConnected", false );
            @user_is_administrator = get_session_boolean( context, "UserIsAdministrator", false );
            @user_has_subscribed = get_session_boolean( context, "UserHasSubscribed", false );
        end

        # -- OPERATIONS

        def store(
            context : HTTP::Server::Context
            ) : Void

            set_session_string( context, "Path", @path );
            set_session_string( context, "Message", @message );
            set_session_integer( context, "UserId", @user_id );
            set_session_boolean( context, "UserIsConnected", @user_is_connected );
            set_session_boolean( context, "UserIsAdministrator", @user_is_administrator );
            set_session_boolean( context, "UserHasSubscribed", @user_has_subscribed );
        end

        # ~~

        def set_session_boolean(
            context : HTTP::Server::Context,
            key : String,
            boolean : Bool
            )

            context.session.bool( key, boolean );
        end

        # ~~

        def get_session_boolean(
            context : HTTP::Server::Context,
            key : String,
            default_boolean : Bool
            ) : Bool

            boolean = context.session.bool?( key );

            if ( boolean.nil?() )

                return default_boolean;

            else

                return boolean;
            end
        end

        # ~~

        def set_session_integer(
            context : HTTP::Server::Context,
            key : String,
            integer : Int32
            )

            context.session.int( key, integer );
        end

        # ~~

        def get_session_integer(
            context : HTTP::Server::Context,
            key : String,
            default_integer : Int32
            ) : Int32

            integer = context.session.int?( key );

            if ( integer.nil?() )

                return default_integer;

            else

                return integer;
            end
        end

        # ~~

        def set_session_string(
            context : HTTP::Server::Context,
            key : String,
            string : String
            )

            context.session.string( key, string );
        end

        # ~~

        def get_session_string(
            context : HTTP::Server::Context,
            key : String,
            default_string : String
            ) : String

            string = context.session.string?( key );

            if ( string.nil?() )

                return default_string;

            else

                return string;
            end
        end
    end
end
