
/**
*OAUTH CLIENT PARAMETERS
*
*
*client_id
*
*The client_id is a public identifier for apps. Even though it’s public, it’s best that it isn’t guessable by third parties, 
*so many implementations use something like a 32-character hex string. It must also be unique across all clients 
*that the authorization server handles. If the client ID is guessable, it makes it slightly easier to craft phishing attacks
*against arbitrary applications
*If the developer is creating a “public” app (a mobile or single-page app), then you should not issue a client_secret
* to the app at all. This is the only way to ensure the developer won’t accidentally include it in their application. 
*If it doesn’t exist, it can’t be leaked!
*
*
*resource_ids
*
*Your resources should check the resource ID before they allow access. This is basically a user input key that identifies 
*a user resource. It comes along with the OAuth2 data retrieved from the server. If we are using Spring Boot's OAuth2 
*implimentation then this is done automatically in the  OAuth2AuthenticationManager.  If we are not using that and go for 
*a straignt implimentation (which is actually the simplest way to perform auth) we must faithfully check the resource ID to 
*grant access. 
*
*
*client_secret
*
*The client_secret is a secret known only to the application and the authorization server. It must be sufficiently random 
*to not be guessable, which means you should avoid using common UUID libraries which often take into account the
* timestamp or MAC address of the server generating it. A great way to generate a secure secret is to use a 
*cryptographically-secure library to generate a 256-bit value and converting it to a hexadecimal representation.
*
*
*scope
*
*The user can define scope's. A good place to start with defining scopes is to define read vs write separately. 
*This works well for Twitter, since not all apps actually want to be able to post content to your Twitter account, some just
*need to access your profile information.
*The challenge when defining scopes for your service is to not get carried away with defining too many scopes. 
*Users need to be able to understand the scope of the authorization they are granting, and this will be presented to the 
*user in a list. When presented to the user, they need to actually understand what is going on. If you over-complicate it
*for users, they will just click “ok” until the app works, and ignore any warnings.
*
*
*authorized_grant_types
*
*The most common OAuth 2.0 grant types are listed below.
*1.Authorization Code
*					The Authorization Code grant type is used by confidential and public clients to exchange an authorization code for an access token.
*					After the user returns to the client via the redirect URL, the application will get the authorization code from the URL and use it to request an access token.
*					This is the most sterio typical case, where a user enters username and password and the application checks the validity of the password to return a token
*2.Implicit
*					The Implicit grant type is a simplified flow that can be used by public clients, where the access token is returned immediately without an extra 
*					authorization code exchange step.
*					It is generally not recommended to use the implicit flow (and some servers prohibit this flow entirely). In the time since the spec was originally written,
*					the industry best practice has changed to recommend that public clients should use the authorization code flow with the PKCE(Proof Key for Code Exchange) 
*					extension instead.
*3.Password
*					The Password grant type is used by first-party clients to exchange a user's credentials for an access token.
*					Since this involves the client asking the user for their password, it should not be used by third party clients. In this flow, the user's username and password 
*					are exchanged directly for an access token.
*4.Client Credentials
*					The Client Credentials grant type is used by clients to obtain an access token outside of the context of a user.
*					This is typically used by clients to access resources about themselves rather than to access a user's resources.
*5.Device Code
*					Now a days, the se of this is increasing significantly. This grant type is mostly used for 2 phase authentication. The requesting device will poll for the auth server
*					till the user permits or denies the request on thei second device (this could be a mobile phone for example)
*6.Refresh Token*
*					This is pretty straight forward, a device uses this grant type for a refresh token
*
*BUILDING A SAMPLE CLIENT
*
*Lets create a client that makes use of this schema. 
*client_id: sample_client_id,
*resource_ids: sample_resource
*client_secret:  secret
*scope: read,write (as a string list coma seperated)
*authorized_grant_types: implicit
*
*
*/
drop table if exists oauth_client_details;
create table oauth_client_details (
  client_id VARCHAR(255) PRIMARY KEY,
  resource_ids VARCHAR(255),
  client_secret VARCHAR(255),
  scope VARCHAR(255),
  authorized_grant_types VARCHAR(255),
  web_server_redirect_uri VARCHAR(255),
  authorities VARCHAR(255),
  access_token_validity INTEGER,
  refresh_token_validity INTEGER,
  additional_information VARCHAR(4096),
  autoapprove VARCHAR(255)
);
 
drop table if exists oauth_client_token;
create table oauth_client_token (
  token_id VARCHAR(255),
  token LONG VARBINARY,
  authentication_id VARCHAR(255) PRIMARY KEY,
  user_name VARCHAR(255),
  client_id VARCHAR(255)
);
 
drop table if exists oauth_access_token;
create table oauth_access_token (
  token_id VARCHAR(255),
  token LONG VARBINARY,
  authentication_id VARCHAR(255) PRIMARY KEY,
  user_name VARCHAR(255),
  client_id VARCHAR(255),
  authentication LONG VARBINARY,
  refresh_token VARCHAR(255)
);
 
drop table if exists oauth_refresh_token;
create table oauth_refresh_token (
  token_id VARCHAR(255),
  token LONG VARBINARY,
  authentication LONG VARBINARY
);
 
drop table if exists oauth_code;
create table oauth_code (
  code VARCHAR(255), authentication LONG VARBINARY
);
 
drop table if exists oauth_approvals;
create table oauth_approvals (
    userId VARCHAR(255),
    clientId VARCHAR(255),
    scope VARCHAR(255),
    status VARCHAR(10),
    expiresAt TIMESTAMP,
    lastModifiedAt TIMESTAMP
);
 
drop table if exists ClientDetails;
create table ClientDetails (
  appId VARCHAR(255) PRIMARY KEY,
  resourceIds VARCHAR(255),
  appSecret VARCHAR(255),
  scope VARCHAR(255),
  grantTypes VARCHAR(255),
  redirectUrl VARCHAR(255),
  authorities VARCHAR(255),
  access_token_validity INTEGER,
  refresh_token_validity INTEGER,
  additionalInformation VARCHAR(4096),
  autoApproveScopes VARCHAR(255)
);

/**
*User tables used in OAuth2 process
*/
drop table if exists users;
create table users(
	username varchar(50) not null primary key,
	password varchar(100) not null,
	enabled boolean not null
);

drop table if exists authorities;
create table authorities (
	username varchar(50) not null,
	authority varchar(50) not null,
	constraint fk_authorities_users foreign key(username) references users(username)
);

INSERT INTO oauth_client_details(client_id, client_secret, scope, authorized_grant_types,web_server_redirect_uri, authorities, access_token_validity,refresh_token_validity, additional_information, autoapprove)
VALUES("fooClientIdPassword", "secret", "oo,read,write","password,authorization_code,refresh_token", null, null, 36000, 36000, null, true);
insert into users(username,password,enabled) values('admin','$2a$10$hbxecwitQQ.dDT4JOFzQAulNySFwEpaFLw38jda6Td.Y/cOiRzDFu',true);
insert into authorities(username,authority)  values('admin','ROLE_ADMIN');