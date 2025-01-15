# Base image for frontend (stage 1)
FROM node:21 as frontend-build

WORKDIR /frontend

# Copy frontend source files
COPY ./frontend/package*.json ./frontend/
RUN npm install

COPY ./frontend ./

# Build the frontend
RUN npm run build

# Base image for backend (stage 2)
FROM node:21 as backend-build

WORKDIR /backend

# Copy backend source files
COPY ./backend/package*.json ./backend/
RUN npm install

COPY ./backend ./

# Install production dependencies for the backend
RUN npm run build

# Production image (final stage)
FROM node:21 as production

# Set work directory
WORKDIR /app

# Copy the built frontend from stage 1
COPY --from=frontend-build /frontend/dist ./frontend/dist

# Copy the backend files from stage 2
COPY --from=backend-build /backend .

# Set environment variables
ENV NODE_ENV=production

# Expose required ports
EXPOSE 5000 5173

# Start the backend and serve frontend
CMD ["npm", "start"]
