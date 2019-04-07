package com.authServer.OauthConfiguration;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.oauth2.config.annotation.configurers.ClientDetailsServiceConfigurer;
import org.springframework.security.oauth2.config.annotation.web.configuration.AuthorizationServerConfigurerAdapter;
import org.springframework.security.oauth2.config.annotation.web.configuration.EnableAuthorizationServer;
import org.springframework.security.oauth2.config.annotation.web.configurers.AuthorizationServerEndpointsConfigurer;
import org.springframework.security.oauth2.config.annotation.web.configurers.AuthorizationServerSecurityConfigurer;
import org.springframework.security.oauth2.provider.token.TokenStore;
import org.springframework.security.oauth2.provider.token.store.JdbcTokenStore;

/**
 * 
 * @author neshantsomanath
 * 
 * /oauth/token  configured by: configure(AuthorizationServerSecurityConfigurer oauthServer)
 * DESIGN: allow all parties to access this end point
 * 
 *
 */
@Configuration
@EnableAuthorizationServer
public class AuthServerOAuth2Config extends AuthorizationServerConfigurerAdapter {
	
	@Autowired
    @Qualifier("authenticationManagerBean")
    private AuthenticationManager authenticationManager;
	
	
	/**
	 * We can either create the data source been externally or like used in the code we can leverage
	 * spring boot's auto generated been. Spring boots auto generated been uses the property files to 
	 * populate these values. 
	 * @Bean
		public DataSource dataSource() {
		    DriverManagerDataSource dataSource = new DriverManagerDataSource();
		    dataSource.setDriverClassName(env.getProperty("jdbc.driverClassName"));
		    dataSource.setUrl(env.getProperty("jdbc.url"));
		    dataSource.setUsername(env.getProperty("jdbc.user"));
		    dataSource.setPassword(env.getProperty("jdbc.pass"));
		    return dataSource;
		    }
	 */
	@Autowired
	DataSource dataSource;
	
	/**
	 * Define security constraints on the token endpoint. 
	 * update the defaults to 'permitAll()' for getting a token and 'isAuthenticated()' 
	 * for checking if a token is valid. 
	 * 
	 * Configure the security of the Authorization Server, which means in practical terms the /oauth/token endpoint. 
	 * The /oauth/authorize endpoint also needs to be secure, but that is a normal user-facing endpoint and should
	 * be secured the same way as the rest of your UI, so is not covered here. The default settings cover the most 
	 * common requirements, following recommendations from the OAuth2 spec, so you don't need to do anything here to 
	 * get a basic server up and running.
	 */
	@Override
    public void configure(AuthorizationServerSecurityConfigurer oauthServer) throws Exception {
        oauthServer
          .tokenKeyAccess("permitAll()")
          .checkTokenAccess("isAuthenticated()")
          .allowFormAuthenticationForClients();
    }
	
	/**
	 * Configure the ClientDetailsService, e.g. declaring individual clients and their properties. 
	 * Note that password grant is not enabled (even if some clients are allowed it) unless an AuthenticationManager 
	 * is supplied to the AuthorizationServerConfigurer.configure(AuthorizationServerEndpointsConfigurer). At least 
	 * one client, or a fully formed custom ClientDetailsService must be declared or the server will not start.
	 */
	@Override
    public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
		/**
		 * Use the below format to register a in-memory client. 
		 * For a better client design, this should be done by a ClientDetailsService (similar to UserDetailsService).
		 * 
		 * clients
            .inMemory()

            .withClient("trusted-app")
                .authorizedGrantTypes("client_credentials", "password", "refresh_token")
                .authorities(Role.ROLE_TRUSTED_CLIENT.toString())
                .scopes("read", "write")
                .resourceIds(resourceId)
                .accessTokenValiditySeconds(10)
                .refreshTokenValiditySeconds(30000)
                .secret("secret")
            .and()
            .withClient("register-app")
                .authorizedGrantTypes("client_credentials")
                .authorities(Role.ROLE_REGISTER.toString())
                .scopes("registerUser")
                .accessTokenValiditySeconds(10)
                .refreshTokenValiditySeconds(10)
                .resourceIds(resourceId)
                .secret("secret");
		 * 
		 * Alternatively we can also use JDBC client data source. In this case the client details are stored in a table.
		 * We can have a external process to append records to this table. ( Like a Form or google auth process, In the 
		 * most extreme cases it can also be used as a service like Auth0)
		 */
		clients.jdbc(dataSource);
	}
	
	/**
	 * Configure the non-security features of the Authorization Server endpoints, like token store, token customizations, 
	 * user approvals and grant types. You shouldn't need to do anything by default, unless you need password grants, 
	 * in which case you need to provide an AuthenticationManager.
	 * 
	 * PASSWORD GRANTS
	 * The Password grant type is used by first-party clients to exchange a user's credentials for an access token. 
	 * Since this involves the client asking the user for their password, it should not be used by third party clients. 
	 * In this flow, the user's username and password are exchanged directly for an access token.
	 *  @Component
		public class CustomAuthenticationProvider implements AuthenticationProvider {
		 
		    @Override
		    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
		  
		        String name = authentication.getName();
		        String password = authentication.getCredentials().toString();
		         
		        if (shouldAuthenticateAgainstThirdPartySystem()) {
		  
		            // use the credentials and authenticate against the third-party system
		            return new UsernamePasswordAuthenticationToken(name, password, new ArrayList<>());
		        } else {
		            return null;
		        }
		    }
		 
		    @Override
		    public boolean supports(Class<?> authentication) {
		        return authentication.equals(
		          UsernamePasswordAuthenticationToken.class);
		    }
		}
	 */
	@Override
    public void configure(AuthorizationServerEndpointsConfigurer endpoints)  throws Exception {
		endpoints
          .tokenStore(tokenStore())
          .authenticationManager(authenticationManager);
    }
 
    @Bean
    public TokenStore tokenStore() {
        return new JdbcTokenStore(dataSource);
    }
	

}
