import requests
import BeautifulSoup as bs
import sys
import traceback
import ConfigParser

def createSession(url):
	session = requests.Session()
	html = session.get(url)
	cookies = session.cookies.get_dict()
	parsed_html = bs.BeautifulSoup(html.text)
	authenticity_token = ""
	pw_reset_token = ""	
	
	try:
		authenticity_token = parsed_html.head.find('meta', attrs ={'name':'csrf-token'})['content']
	except Exception, e:
		authenticity_token = 'none'
		print 'no authenticity_token'
		exit()
	
	try:
		pw_reset_token = html.url.split('=')[1]
	except Exception, e:
		pw_reset_token = 'none'
		print 'no pw reset token'				

	sessionData = {
		'session' : session,
		'authenticity_token' : authenticity_token,
		'pw_reset_token' : pw_reset_token,
		'cookies' : cookies,
		'url' : url
	}
	return sessionData

def initializeRootAccount(sessionData, root_pw):
	session = sessionData['session']
	#create payload for changing root pw
	payload = {
		'_method':'put',
		'authenticity_token':sessionData['authenticity_token'],
		'user[reset_password_token]':pw_reset_token['pw_reset_token'],
		'user[password]':root_pw,
		'user[password_confirmation]':root_pw
	}

	result = session.post(sessionData['url']+"/users/password", data=payload, cookies=sessionData['cookies'])
	print result.status_code

def registerUser(sessionData, user_name, user_username, user_email, user_pw):
	session = sessionData['session']
	#create payload for registering user
	payload = {
		'authenticity_token':sessionData['authenticity_token'],
		'new_user[name]':user_name,
		'new_user[username]':user_username,
		'new_user[email]':user_email,
		'new_user[email_confirmation]':user_email,
		'new_user[password]':user_pw		
	}

	result = session.post(sessionData['url']+"/users", data=payload, cookies=sessionData['cookies'])
	print result.status_code

def createAPIToken(sessionData, config):
	session = sessionData['session']
	token_name = config.get('api', 'token_name')

	#create payload for user's api token
	payload = {
		'authenticity_token':sessionData['authenticity_token'],
		'personal_access_token[name]':token_name,
		'personal_access_token[expires_at]':'',
		'personal_access_token[scopes][]':'api'
	}	

	result = session.post(sessionData['url'], cookies=sessionData['cookies'], data=payload)
	print result.text

def readConfig():
	Config = ConfigParser.ConfigParser()
	Config.read('config.py')
	print Config.sections()
	return Config

def main(argv):
	# test vars - convert this to read from config plz
	url = "sample"
	root_pw = "sample val"
	user_name = "sample"
	user_username = "sample"
	user_email = "sample"
	user_pw = "sample"

	sessionData = createSession(url)
	#initializeRootAccount(sessionData, pw)	
	registerUser(sessionData, user_name, user_username, user_email, user_pw)
	config = readConfig()
	createAPIToken(sessionData, config)	

if __name__ == "__main__":
	main(sys.argv)

