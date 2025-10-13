import logger from '#config/logger.js';
import bcrypt from 'bcrypt';
import { db } from '#config/database.js';
import { eq } from 'drizzle-orm';
import users from '#models/users.model.js';

export const hashPassword = async password => {
  try {
    return await bcrypt.hash(password, 10);
  } catch (error) {
    logger.error(`Error hashing the password: ${error}`);
    throw new Error('Error occures while Hashing');
  }
};

export const comparePassword = async (password, hashedPassword) => {
  try {
    return await bcrypt.compare(password, hashedPassword);
  } catch (error) {
    logger.error(`Error comparing the password: ${error}`);
    throw new Error('Error occurred while comparing password');
  }
};

export const authenticateUser = async ({ email, inputPassword }) => {
  try {
    // Check if user exists
    const [existingUser] = await db
      .select()
      .from(users)
      .where(eq(users.email, email))
      .limit(1);

    if (!existingUser) {
      throw new Error('User not found');
    }

    // Validate password
    const isPasswordValid = await comparePassword(
      inputPassword,
      existingUser.password
    );

    if (!isPasswordValid) {
      throw new Error('Invalid password');
    }

    // Return user without password
    const { ...userWithoutPassword } = existingUser;
    logger.info(`User ${existingUser.email} authenticated successfully`);
    return userWithoutPassword;
  } catch (error) {
    logger.error(`Error authenticating user: ${error}`);
    throw error;
  }
};

export const createUser = async ({ name, email, password, role = 'user' }) => {
  try {
    const existUser = await db
      .select()
      .from(users)
      .where(eq(users.email, email))
      .limit(1);

    if (existUser.length > 0) {
      throw new Error('User already exists !!');
    }

    const password_hash = await hashPassword(password);

    const [newUser] = await db
      .insert(users)
      .values({ name, email, password: password_hash, role })
      .returning({
        id: users.id,
        name: users.name,
        email: users.email,
        role: users.role,
        created_at: users.created_at,
      });

    logger.info(`User ${newUser.email} created successfully`);
    return newUser; // Fix: Return the created user
  } catch (error) {
    logger.error(`Error creating the user: ${error}`);
    throw error;
  }
};
