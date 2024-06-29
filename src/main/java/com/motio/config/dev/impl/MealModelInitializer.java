package com.motio.config.dev.impl;

import com.motio.config.dev.ModelInitializer;
import com.motio.model.Meal;
import com.motio.model.MealCategory;
import com.motio.model.User;
import com.motio.service.MealService;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.Validate;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Component
@RequiredArgsConstructor
public class MealModelInitializer implements ModelInitializer<Meal> {
    private static final Random random = new Random();
    private static final List<String> possibleIngredients = List.of(
            "Mąka", "Cukier", "Sól", "Masło", "Mleko", "Jajka", "Ser", "Pomidory",
            "Cebula", "Czosnek", "Kurczak", "Wołowina", "Wieprzowina", "Ryba", "Marchew", "Ziemniaki",
            "Papryka", "Oliwa z oliwek", "Bazylia", "Oregano", "Tymianek", "Rozmaryn", "Sałata",
            "Szpinak", "Ogórek", "Awokado", "Kukurydza", "Ryż", "Makaron", "Fasola"
    );
    private static final List<String> possibleSteps = List.of(
            "Rozgrzej piekarnik do 350°F (175°C)", "Wymieszaj składniki w misce", "Piec przez 30 minut",
            "Mieszaj od czasu do czasu", "Drobno posiekaj warzywa", "Grilluj po 10 minut z każdej strony",
            "Gotuj na wolnym ogniu przez 20 minut", "Podawaj z dodatkiem ryżu", "Ozdób świeżymi ziołami",
            "Odstaw na 10 minut", "Ubijać do uzyskania gładkiej konsystencji", "Podgrzej olej na patelni",
            "Połącz składniki w blenderze", "Marynuj mięso przez 2 godziny", "Zagotuj wodę i dodaj makaron"
    );
    private static final List<String> possibleMeals = List.of(
            "Kurczak w sosie ziołowym", "Pieczone ziemniaki z czosnkiem", "Makaron z sosem pomidorowym",
            "Sałatka grecka", "Gulasz wołowy", "Tortilla z kurczakiem", "Placki ziemniaczane",
            "Zupa krem z marchewki", "Sandacz w panierce", "Ryż z warzywami", "Pasta z awokado",
            "Sałatka cezar", "Lasagna z warzywami", "Kotlety mielone", "Risotto z grzybami",
            "Kanapki z serem i szpinakiem", "Pizza margherita", "Szaszłyki z kurczaka",
            "Omlet z warzywami", "Burrito z fasolą", "Zupa pomidorowa", "Pstrąg z masłem czosnkowym",
            "Frytki z batatów", "Pierogi z mięsem", "Sałatka z krewetkami", "Tarta z pomidorami",
            "Chili con carne", "Curry z kurczakiem", "Naleśniki z serem", "Zapiekanka ziemniaczana",
            "Tacos z wołowiną"
    );
    private final MealService mealService;
    private Collection<MealCategory> providedCategories;
    private Collection<User> providedUsers;

    private static <T> List<T> getRandomElements(List<T> list, int count) {
        return random.ints(0, list.size())
                .distinct()
                .limit(count)
                .mapToObj(list::get)
                .collect(Collectors.toList());
    }

    @Override
    @SuppressWarnings("unchecked")
    public void addContextObjects(Collection<?> objects, Class<?> type) {
        if (type.isAssignableFrom(MealCategory.class)) {
            providedCategories = (Collection<MealCategory>) objects;
        } else if (type.isAssignableFrom(User.class)) {
            providedUsers = (Collection<User>) objects;
        } else {
            throw new RuntimeException("Could not apply context objects during data initialization");
        }
    }

    @Override
    public Collection<Meal> initializeObjects() {
        Validate.notEmpty(providedCategories);
        Validate.notEmpty(providedUsers);

        List<MealCategory> mealCategories = List.copyOf(providedCategories);
        List<User> users = List.copyOf(providedUsers);

        List<Meal> loadedMeals = new LinkedList<>();

        IntStream.range(1, 101).forEach(i -> {
            List<MealCategory> categories = getRandomElements(mealCategories, 1 + random.nextInt(3));
            User creator = users.get(random.nextInt(users.size()));
            Set<User> accessibleUsers = new HashSet<>(users);
            accessibleUsers.remove(creator);

            List<String> steps = getRandomElements(possibleSteps, 4 + random.nextInt(3));
            List<String> ingredients = getRandomElements(possibleIngredients, 4 + random.nextInt(3));
            String imageUrl = "https://i.ibb.co/YD14M97/italian-food.png";
            String mealName = possibleMeals.get(random.nextInt(possibleMeals.size()));

            Meal meal = new Meal(null, mealName, creator, accessibleUsers, new HashSet<>(categories), steps, ingredients, imageUrl);
            loadedMeals.add(mealService.saveMeal(meal));
        });
        return loadedMeals;
    }

    @Override
    public void destroy() {
        //do nothing
    }
}
