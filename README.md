# CoreData to SQL

![Swift](https://github.com/phimage/cd2sql/workflows/Swift/badge.svg)
![release](https://github.com/phimage/cd2sql/workflows/release/badge.svg)

Convert CoreData model to SQL

## Install

### Using release

Go to https://github.com/phimage/cd2sql/releases and take the last binary for macOS cd2sql.zip

### Using sources

```
git clone https://github.com/phimage/cd2sql.git
cd cd2sql
swift build -c release
```

Binary result in `.build/release/cd2sql`

## Usage

```
cd2sql <core data model>
```

### example

```
cd2sql /path/to/MyModel.xcdatamodeld
```

```sql
CREATE TABLE Personne (
    FirstName VARCHAR,
    LastName VARCHAR,
    ID INTEGER PRIMARY KEY
);
```
