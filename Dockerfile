#Build stage
FROM node:22.7.0-alpine3.20 AS builder

# Working DIR 
WORKDIR /app

# Copy the source code
COPY . .

# Install build dependencies
RUN npm install

# Build stop 
RUN npm run build

#Production stage
FROM node:22.7.0-alpine3.20 AS production

# ENV 
ENV PORT="" \
    BUCKET_NAME=""

# Working DIR 
WORKDIR /app

COPY --from=builder /app/package*.json .

RUN npm ci --only=production

# Copy only the necessary files from the builder stage
COPY --from=builder /app/dist .

# Use a non-root user and group (for Node conatiner it is a node user )
RUN chown -R node:node /app \
    && chmod -R 755 /app

# Switch to non-root user
USER node

EXPOSE 3000

CMD ["node", "index.js"]