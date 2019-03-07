from datetime import datetime
import math, subprocess

emails = ['noreply@github.com', 'noreply@github.com', 'noreply@github.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'maruf@Marufs-Workstation.local', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com', 'rayhan1.618@gmail.com']
dates = ['2018-12-12T07:30:03Z', '2018-12-12T07:29:48Z', '2018-12-12T07:25:18Z', '2018-12-12T01:05:28Z', '2018-12-12T00:56:42Z', '2018-12-11T23:58:34Z', '2018-12-11T23:11:45Z', '2018-12-06T19:30:54Z', '2018-12-06T17:04:40Z', '2018-11-23T05:59:57Z', '2018-11-12T00:42:06Z', '2018-11-12T00:39:38Z', '2018-11-08T15:57:46Z', '2018-11-02T16:18:25Z', '2018-11-02T16:16:54Z', '2018-11-02T16:15:29Z', '2018-11-02T16:13:05Z', '2018-11-02T16:12:40Z', '2018-11-01T23:43:39Z', '2018-11-01T23:41:16Z', '2018-11-01T23:41:02Z', '2018-10-22T01:50:29Z', '2018-10-19T03:40:58Z', '2018-10-18T02:29:45Z', '2018-10-18T00:46:03Z', '2018-10-17T00:11:00Z', '2018-10-15T18:17:14Z', '2018-10-07T05:47:25Z', '2018-09-09T16:04:36Z', '2018-09-08T02:57:59Z', '2018-09-03T02:51:50Z', '2018-09-02T21:25:55Z', '2018-09-02T21:25:13Z', '2018-09-02T21:23:19Z']
dts = []
for item in dates:
    dt = datetime.strptime(item, '%Y-%m-%dT%H:%M:%SZ')
    dts.append(dt)


print(len(dates))
print(f'{math.fabs(((dts[-1] - dts[0]).days)/30)}')

authors = set(emails)
print(authors)

# for commit in commits:
#     author_emails.append(commit.raw_data['commit']['committer']['email'])
#     commit_dates.append(commit.raw_data['commit']['committer']['date'])
#
# parsedCommitDates = []
# for item in commit_dates:
#     commitDateAndTime = datetime.strptime(item, '%Y-%m-%dT%H:%M:%SZ')
#     parsedCommitDates.append(commitDateAndTime)
# if math.fabs(((parsedCommitDates[-1] - parsedCommitDates[0]).days) / 30) > 0:
#     commitsPerMonth = len(parsedCommitDates) / math.ceil(
#         math.fabs(((parsedCommitDates[-1] - parsedCommitDates[0]).days) / 30))
# else:
#     commitsPerMonth = 0
# uniqueAuthors = set(author_emails)
