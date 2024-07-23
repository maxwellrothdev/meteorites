import pandas as pd
from geopy.geocoders import Nominatim
from geopy.extra.rate_limiter import RateLimiter
import os
import sys


# Instantiate Nominatim client
geolocator = Nominatim(user_agent="geolocation_program", timeout=120)
rgeocode = RateLimiter(geolocator.reverse, min_delay_seconds=2)


def main():
    # Prompt for filename and check exists
    input_filename = input(f"Input filename: ").strip()
    check_file_exists(input_filename, filetype="input")

    # Read CSV to DataFrame
    df = pd.read_csv(input_filename)

    # Prompt for column "geolocation" and check exists
    column_name = input(f"Column name: ").strip()
    check_column_exists(column_name, df, input_filename)

    # Duplicate column to 'country', clean/remove parentheses
    df['country'] = df[column_name].str.replace(r"[()]", '', regex=True)

    # Assign batch size
    BATCH_SIZE = 100

    # Apply reverse geolocation function get_country to all rows/len column 'country' in assigned batch size 100
    for start in range(0, len(df), BATCH_SIZE):
        end = min(start + BATCH_SIZE, len(df))
        # Print progress
        print(f"Processing rows {start+1} to {end}...")
        df.loc[start:end-1, 'country'] = df.loc[start:end-1, 'country'].apply(get_country)

    # Prompt for output filename and check does not already exist
    output_filename = input(f"Output filename: ").strip()
    check_file_exists(output_filename, filetype="output")

    # Prompt to verify save or cancel/exit program
    if verify_save(output_filename):
        # Save updated DataFrame to CSV
        df.to_csv(output_filename, index=False)
        # Print verification
        print("Successfully saved CSV file.")
    else:
        # Cancel/exit program
        sys.exit("File not saved. Exiting program.")


# Check if input filename exists based on filetype
def check_file_exists(filename, filetype):
    if filetype == "input" and not os.path.exists(filename):
        raise FileNotFoundError(f"File '{filename}' does not exist.")
    elif filetype == "output" and os.path.exists(filename):
        raise FileExistsError(f"File '{filename}' already exists.")


# Check column name exists in DataFrame/CSV
def check_column_exists(column, df, filename):
    if column not in df.columns:
        raise ValueError(f"Column name '{column}' does not exist in '{filename}'.")


# Takes arg (coordinates) returns country, if not NULL or empty string: ''
def get_country(geolocation):
    if pd.notnull(geolocation) and geolocation != '':
        try:
            # Retrieve geolocation data
            location = geolocator.reverse(geolocation, language="en").raw
            # Check location data not None
            if location is not None:
                # Return country data
                return location['address']['country']
            else:
                return ''
        # Handle KeyError exception
        except (KeyError, AttributeError):
            return ''


# Verify save or cancel/exit program
def verify_save(filename):
        # Loop until True/input valid
        while True:
            answer = input(f"Are you sure you want to save {filename}? Please enter 'y' to continue or 'n' to cancel and exit program: ").strip().lower()
            if answer in ["y", "yes"]:
                return True
            elif answer in ["n", "no"]:
                return False
            else:
                print("Invalid input.")


if __name__ == "__main__":
     main()