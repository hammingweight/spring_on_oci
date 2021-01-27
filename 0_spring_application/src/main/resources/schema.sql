-- we'll map names to number of visits to ur API endpoint.
CREATE TABLE IF NOT EXISTS visitors (
    name VARCHAR(50) NOT NULL,
    num_visits NUMBER,
    PRIMARY KEY(name)
);
