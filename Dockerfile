# Base image
FROM  node

# Create the desired src folder
WORKDIR src

# Copy the required files
COPY  ./app  .

# Install the npm packages
RUN   npm  i

# Start the server
CMD   node index.js