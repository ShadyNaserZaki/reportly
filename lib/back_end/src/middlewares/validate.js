import { ValidationError } from '../utils/errors.js';

export const validate = (schema) => {
    return (req, res, next) => {
        try {
            const { error, value } = schema.validate(req.body, {
                abortEarly: false,
                stripUnknown: true,
                errors: {
                    wrap: {
                        label: ''
                    }
                }
            });
            
            if (error) {
                const errorMessages = error.details.map(detail => detail.message).join(', ');
                throw new ValidationError(errorMessages);
            }
            
            // Store validated data
            req.validatedData = value;
            next();
        } catch (err) {
            next(err);
        }
    };
};