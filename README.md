# We::GitHubStats

Print some annual stats about your organizations repositories.

- Number of Commits
- Number of Lines Added
- Number of Lines Deleted

Nothing super fancy, and this isn't tested so don't use it for anything in production. Not sure how you would, but please don't.

## Installation

Run the following:

```
$ gem install we-github-stats
```

## Usage

This gem does everything we need to get the job done, but it’s a little primitive.

```
$ github_stats -o wework -t super-secret-token
```

That will output a table for the repos that are done, count up the totals, and let you know if any are still being calculated by GitHub:

```
ERROR! The following stats are not ready on the GitHub API:
 - wework.github.io
 - we-learn-react
 - we-interview
 - we-js-logger
 - careday-api
 - dotenv-rails-safe
 - careday-app
 - eslint-config-wework
 - we-github-stats
Please wait a few minutes and try again. In the meantime, the stats for other repos are...

==== Repositories ====
+---------------+---------+-------------+---------------+
| Name          | Commits | Lines Added | Lines Removed |
+---------------+---------+-------------+---------------+
| env-universal | 54      | 2358        | -692          |
+---------------+---------+-------------+---------------+
==== Total ====
Total Commits: 54
Total Lines Added: 2358
Total Lines Removed: -692
```

Run a few minutes later, you’ll see:

```
==== Repositories ====
+-----------------------+---------+-------------+---------------+
| Name                  | Commits | Lines Added | Lines Removed |
+-----------------------+---------+-------------+---------------+
| wework.github.io      | 27      | 357         | -208          |
| we-learn-react        | 0       | 0           | 0             |
| we-interview          | 0       | 0           | 0             |
| we-js-logger          | 64      | 2914        | -1037         |
| env-universal         | 54      | 2358        | -692          |
| careday-api           | 7       | 3223        | -628          |
| dotenv-rails-safe     | 21      | 737         | -281          |
| careday-app           | 15      | 1686        | -434          |
| eslint-config-wework  | 4       | 347         | -3            |
| we-github-stats       | 2       | 384         | -23           |
+-----------------------+---------+-------------+---------------+
==== Total ====
Total Commits: 233
Total Lines Added: 13166
Total Lines Removed: -3375
```

Want it in CSV? Pass the format parameter:

```
$ github_stats -o wework -t super-secret-token -f csv
```

It’ll give you a header row and a line with these stats for each completed repository. 

```
Name, Commits, Lines Added, Lines Removed
wework.github.io,27,357,-208
we-learn-react,0,0,0
we-interview,0,0,0
we-js-logger,64,2914,-1037
env-universal,54,2358,-692
careday-api,7,3223,-628
dotenv-rails-safe,21,737,-281
careday-app,15,1686,-434
eslint-config-wework,4,347,-3
we-github-stats,2,384,-23
```

## Development
Run tests the same as with our apps
    
    $ rspec spec

## TODO 

1. Handle GitHub API errors instead of [raising a panic](https://github.com/wework/we-github-stats/blob/master/lib/we/github_stats/repository.rb#L34)
1. Concurrent requests because doing these one at a time is _slow_
1. Slim out Cli class, as it's handling far too many things
