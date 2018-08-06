# Usage:

```getmyorgs.sh <username>```

**Login to a cf environment**

```cf login -a https://api.local.pcfdev.io --skip-ssl-validation```

**Find some orgs for ```user201```**

```
./getmyorgs.sh user201
Found 3 pages full of happy little users

The user 'user201' is a member of the following orgs:
foo-org
bar-org
```
