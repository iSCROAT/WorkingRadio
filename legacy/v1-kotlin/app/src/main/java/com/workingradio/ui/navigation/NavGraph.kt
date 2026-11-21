package com.workingradio.ui.navigation

import androidx.compose.runtime.Composable
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.workingradio.data.RadioRepository
import com.workingradio.data.WeatherRepository
import com.workingradio.ui.screens.HomeScreen
import com.workingradio.ui.screens.SettingsScreen
import com.workingradio.ui.screens.WeatherScreen
import com.workingradio.ui.viewmodel.RadioViewModel
import com.workingradio.ui.viewmodel.WeatherViewModel

object Routes {
    const val HOME = "home"
    const val WEATHER = "weather"
    const val SETTINGS = "settings"
}

@Composable
fun WorkingRadioNavGraph(
    radioRepository: RadioRepository,
    weatherRepository: WeatherRepository,
    navController: NavHostController = rememberNavController()
) {
    val radioViewModel: RadioViewModel = viewModel(factory = RadioViewModel.factory(radioRepository))
    val weatherViewModel: WeatherViewModel = viewModel(factory = WeatherViewModel.factory(weatherRepository))

    NavHost(navController = navController, startDestination = Routes.HOME) {
        composable(Routes.HOME) {
            HomeScreen(
                viewModel = radioViewModel,
                onOpenWeather = { navController.navigate(Routes.WEATHER) },
                onOpenSettings = { navController.navigate(Routes.SETTINGS) }
            )
        }
        composable(Routes.WEATHER) {
            WeatherScreen(
                weatherViewModel = weatherViewModel,
                radioViewModel = radioViewModel,
                onBack = { navController.popBackStack() }
            )
        }
        composable(Routes.SETTINGS) {
            SettingsScreen(
                onBack = { navController.popBackStack() },
                onOpenWeather = { navController.navigate(Routes.WEATHER) }
            )
        }
    }
}
