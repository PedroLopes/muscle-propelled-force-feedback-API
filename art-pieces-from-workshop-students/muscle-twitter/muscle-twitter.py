#!/usr/bin/env python

'''Post a message to twitter'''

__author__ = 'dewitt@google.com'

import ConfigParser
import getopt
import os
import sys
import twitter
import socket

USAGE = '''Usage: tweet [options] message

  This script posts a message to Twitter.

  Options:

    -h --help : print this help
    --consumer-key : the twitter consumer key
    --consumer-secret : the twitter consumer secret
    --access-key : the twitter access token key
    --access-secret : the twitter access token secret
    --encoding : the character set encoding used in input strings, e.g. "utf-8". [optional]

  Documentation:

  If either of the command line flags are not present, the environment
  variables TWEETUSERNAME and TWEETPASSWORD will then be checked for your
  consumer_key or consumer_secret, respectively.

  If neither the command line flags nor the environment variables are
  present, the .tweetrc file, if it exists, can be used to set the
  default consumer_key and consumer_secret.  The file should contain the
  following three lines, replacing *consumer_key* with your consumer key, and
  *consumer_secret* with your consumer secret:

  A skeletal .tweetrc file:

    [Tweet]
    consumer_key: *consumer_key*
    consumer_secret: *consumer_password*
    access_key: *access_key*
    access_secret: *access_password*

'''

#UDP_IP = "127.0.0.1"
UDP_IP = "192.168.1.201"
UDP_PORT = 6000
MESSAGE = "1"

print "UDP target IP:", UDP_IP
print "UDP target port:", UDP_PORT
print "message:", MESSAGE

def PrintUsageAndExit():
  print(USAGE)
  sys.exit(2)

def GetConsumerKeyEnv():
  return os.environ.get("TWEETUSERNAME", None)
def GetConsumerSecretEnv():
  return os.environ.get("TWEETPASSWORD", None)

def GetAccessKeyEnv():
  return os.environ.get("TWEETACCESSKEY", None)

def GetAccessSecretEnv():
  return os.environ.get("TWEETACCESSSECRET", None)
class TweetRc(object):
  def __init__(self):
    self._config = None

  def GetConsumerKey(self):
    return self._GetOption('consumer_key')

  def GetConsumerSecret(self):
    return self._GetOption('consumer_secret')

  def GetAccessKey(self):
    return self._GetOption('access_key')

  def GetAccessSecret(self):
    return self._GetOption('access_secret')

  def _GetOption(self, option):
    try:
      return self._GetConfig().get('Tweet', option)
    except:
      return None

  def _GetConfig(self):
    if not self._config:
      self._config = ConfigParser.ConfigParser()
      self._config.read(os.path.expanduser('~/.tweetrc'))
    return self._config

def main():
  try:
    shortflags = 'h'
    longflags = ['help', 'consumer-key=', 'consumer-secret=', 
                 'access-key=', 'access-secret=', 'encoding=']
    opts, args = getopt.gnu_getopt(sys.argv[1:], shortflags, longflags)
  except getopt.GetoptError:
    PrintUsageAndExit()
  consumer_keyflag = None
  consumer_secretflag = None
  access_keyflag = None
  access_secretflag = None
  encoding = None
  for o, a in opts:
    if o in ("-h", "--help"):
      PrintUsageAndExit()
    if o in ("--consumer-key"):
      consumer_keyflag = a
    if o in ("--consumer-secret"):
      consumer_secretflag = a
    if o in ("--access-key"):
      access_keyflag = a
    if o in ("--access-secret"):
      access_secretflag = a
    if o in ("--encoding"):
      encoding = a
  message = ' '.join(args)
  if not message:
    PrintUsageAndExit()
  print("file")
  rc = TweetRc()
  consumer_key = consumer_keyflag or GetConsumerKeyEnv() or rc.GetConsumerKey()
  print(consumer_key)
  consumer_secret = consumer_secretflag or GetConsumerSecretEnv() or rc.GetConsumerSecret()
  access_key = access_keyflag or GetAccessKeyEnv() or rc.GetAccessKey()
  access_secret = access_secretflag or GetAccessSecretEnv() or rc.GetAccessSecret()
  if not consumer_key or not consumer_secret or not access_key or not access_secret:
    PrintUsageAndExit()
  api = twitter.Api(consumer_key=consumer_key, consumer_secret=consumer_secret,
                    access_token_key=access_key, access_token_secret=access_secret,
                    input_encoding=encoding)
  try:
    statuses = api.GetUserTimeline("ewok_labs")
    #print [s.text for s in statuses]
    #print statuses
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
    sock.sendto(MESSAGE, (UDP_IP, UDP_PORT))

    #for s in statuses:
    #  if ((s.text).find("Killed") > 0):
    #    print("FOUND IT, need to send a network message")
    #    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
    #    sock.sendto(MESSAGE, (UDP_IP, UDP_PORT))

    #statuses = api.GetPublicTimeline()
    #print [s.user.name for s in statuses]

    #status = api.PostUpdate(message)
  except UnicodeDecodeError:
    print("Your message could not be encoded.  Perhaps it contains non-ASCII characters?")
    print("Try explicitly specifying the encoding with the --encoding flag")
    sys.exit(2)
  #print("%s just posted: %s" % (status.user.name, status.text))

if __name__ == "__main__":
  main()
