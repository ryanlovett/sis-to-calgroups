# sis-to-calgroups
CI workflow to create CalGroups from SIS info

This repository fronts a CI process that retrieves some data from
UC Berkeley's SIS and then creates corresponding groups in CalGroups.
Google Groups are then provisioned from CalGroups.

To enable this process for a course, create a new course json file or
modify an existing one in courses/. The only requirements are the course
year, semester, and class section number. The latter may be retrieve from
a search of https://classes.berkeley.edu. Comments can be entered as a key
value.

Example
=======
```
[
 {"year": 2019, "semester": "spring", "class": 24996, "comment": "stat c8"},
 {"year": 2019, "semester": "spring", "class": 28558, "comment": "compsci c100"},
 {"year": 2019, "semester": "spring", "class": 25622, "comment": "prob 140"}
]
```
