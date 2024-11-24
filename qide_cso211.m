
clc; clear;

% Parameters
pop_size = 100;         % Population size
max_gen = 200;          % Maximum number of generations
dim = 2;                % Problem dimension (a1 and a2 angles)
F = 0.7;                % Mutation factor
CR = 0.85;              % Crossover probability
M = 0.5;                % Modulation index
vdc = 50;               % DC voltage

% Define fitness function (Z)
fitness_function = @(x) calculate_Z(x, M, vdc);

% Initialize population (angles between 0 and 90 degrees)
pop = rand(pop_size, dim) * 90;

% Store fitness values
fitness = zeros(pop_size, 1);
for i = 1:pop_size
    fitness(i) = fitness_function(pop(i, :));
end

% Store best fitness over generations for visualization
best_fitness_history = zeros(max_gen, 1);

% Main QIDE loop
for gen = 1:max_gen
    % Quantum-inspired update (rotation step)
    new_pop = quantum_rotation(pop, fitness, pop_size, dim);
    
    % Differential Evolution Mutation, Crossover, and Selection
    for i = 1:pop_size
        % Mutation (DE/rand/1 strategy)
        idxs = randperm(pop_size, 3);
        while any(idxs == i)
            idxs = randperm(pop_size, 3); % Ensure different individuals
        end
        mutant = pop(idxs(1), :) + F * (pop(idxs(2), :) - pop(idxs(3), :));

        % Ensure the mutant values are within the bounds (0 to 90 degrees)
        mutant = min(max(mutant, 0), 90);
        
        % Crossover
        trial = pop(i, :);
        for j = 1:dim
            if rand() <= CR
                trial(j) = mutant(j);
            end
        end
        
        % Ensure the trial values are within bounds (0 to 90 degrees)
        trial = min(max(trial, 0), 90);

        % Selection
        if fitness_function(trial) < fitness(i)
            pop(i, :) = trial;
            fitness(i) = fitness_function(trial);
        end
    end
    
    % Save the best fitness for visualization
    best_fitness_history(gen) = min(fitness);
    
    % Display progress every 10 generations
    if mod(gen, 10) == 0
        disp(['Generation: ', num2str(gen), ' Best Fitness: ', num2str(best_fitness_history(gen))]);
    end
end

% Output best result
[best_fitness, best_idx] = min(fitness);
best_solution = pop(best_idx, :);

disp('Best solution found:');
disp(['a1 = ', num2str(best_solution(1)), ' degrees']);
disp(['a2 = ', num2str(best_solution(2)), ' degrees']);
disp(['Best fitness value (Z): ', num2str(best_fitness)]);

% Plot the convergence of fitness over generations
figure;
plot(1:max_gen, best_fitness_history, 'LineWidth', 2);
xlabel('Generation');
ylabel('Best Fitness Value (Z)');
title('Convergence of Best Fitness over Generations');
grid on;

%% Fitness function (Z)
function Z = calculate_Z(x, M, vdc)
    a1 = x(1);
    a2 = x(2);
    k = vdc / pi;
    q = 2 * k * M;
    
    q1 = k * (cosd(a1) + cosd(a2));
    q5 = (k / 5) * (cosd(5 * a1) + cosd(5 * a2));
    
    Z = (100 * (q - q1) / q)^4 + ((1 / 5) * (100 * (q5 / q1)))^2;
end

%% Quantum-inspired update (rotation mechanism)
function new_pop = quantum_rotation(pop, fitness, pop_size, dim)
    % Calculate rotation angle based on fitness ranking
    [~, idx] = sort(fitness);  % Sort fitness, smallest first
    best_ind = pop(idx(1), :);  % Best individual
    
    % Rotation angle based on distance to best solution
    theta = 0.05;  % Small rotation angle for fine-tuning
    new_pop = pop;
    
    for i = 1:pop_size
        for j = 1:dim
            % Rotate towards best solution with a random factor
            rotation_direction = sign(best_ind(j) - pop(i, j));
            new_pop(i, j) = pop(i, j) + rotation_direction * theta * randn();
        end
        
        % Keep new population within bounds (0 to 90 degrees)
        new_pop(i, :) = min(max(new_pop(i, :), 0), 90);
    end
end